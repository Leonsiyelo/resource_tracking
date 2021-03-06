#:user is kind of lame without any roles
Factory.define :user, :class => User do |f|
  f.sequence(:username)   { |i| "user_#{i}" }
  f.sequence(:email)      { |i| "user_#{i}@example.com" }
  f.password              { 'password' }
  f.password_confirmation { 'password' }
  f.organization          { Factory(:organization) } #for convenience, though the API assumes you do this first yourself
end

Factory.define :reporter,  :parent => :user do |f|
  f.roles { ['reporter'] }
end

Factory.define :activity_manager,  :parent => :user do |f|
  f.roles { ['activity_manager'] }
end

Factory.define :admin,  :parent => :user do |f|
  f.roles { ['admin'] }
end
