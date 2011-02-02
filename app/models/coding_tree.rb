#  USAGE:
#
#  activity    = Activity.find(889)
#  coding_type = CodingBudget

#  ct = CodingTree.new(activity, coding_type)
#
#  p ct.roots[0].code.short_display
#  p ct.roots[0].ca.cached_amount
#  p ct.roots[0].children[0].code.short_display
#  p ct.roots[0].children[0].children[0].code.short_display
#  p ct.roots[0].children[0].children[0].children[0].code.short_display

class CodingTree
  class Tree
    def initialize(object)
      @object = object
      @children = []
    end

    def <<(object)
      subtree = Tree.new(object)
      @children << subtree
      return subtree
    end

    def children
      @children
    end

    def code
      @object[:code]
    end

    def ca
      @object[:ca]
    end
  end

  def initialize(activity, coding_klass)
    @roots            = []
    codes             = coding_klass.available_codes(activity)
    @code_assignments = coding_klass.with_activity(activity)
    @_root       = Tree.new({})

    build_subtree(@_root, codes)
  end

  def build_subtree(root, codes)
    codes.each do |code|
      code_assignment = @code_assignments.detect{|ca| ca.code_id == code.id}
      if code_assignment
        node = Tree.new({:ca => code_assignment, :code => code})
        root.children << node
        build_subtree(node, code.children) unless code.leaf?
      end
    end
  end

  def roots
    @_root.children
  end
end
