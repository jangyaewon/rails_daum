``` ruby
$ cd ..
$ rails _5.0.6_ new daum_cafe
$ cd daum_cafe
$ rails g scaffold post title:string contents: text 
$ rake routes #경로를 지정??
$ rake db:migrate
```

- rails require

``` ruby
################### posts_controller
def post_params
      params.require(:post).permit(:title, :contents, :text)
 end
```

``` erb
<input type="text" name="title">
<input type="text" name="post[title]">  ----> 스캐폴드에서 하는 방법

<form action="" method=""></form>
<%= form_tag("/posts")%> <% end %>
<%= text_fiels_tag(:description) %>
<%= text_area_tag(:boards) %>
<!-- Post모델의 컬럼과 관련없는 input 태그역시 입력(설정) 가능 -->

<%= form_for(@post) do |f| %> 
	<%= f.text_field(:title) %>
	<%= f.text_area(:contents) %>
	<%= f.text_field(:description) %>	
	<input type="text" name="admin" value="true"> 
		--> 개발자모드에서 이런 코드를 넣으면 비밀번호까지 알수 있는 형식이라 
			이를 방지하기 위해 이와 같은 방식을 사용한다. 
<!-- Post모델의 컬럼과 관련없는 input 태그는 입력(설정) 불가능 -->
<% end %> 
```

### SQL injection

------

http://guides.rubyonrails.org/form_helpers.html

​			이전					form_helper??

| new                               edit | new                     edit                  |
| -------------------------------------- | --------------------------------------------- |
| @post 존재 X       @post 존재          | @post 존재        @post 존재                  |
| 새롭게 넣을 값                         | 빈값(껍데기)       원래있던 값                |
|                                        | @post에 대한 컬럼의 값만 폼으로 받을 수 있다. |
| ```params[:title]                      | ```params[:post][:title]                      |

``` ruby
# 처음에 설정한 값만 들어간다.   
def post_params
   params.require(:post).permit(:title, :contents, :text)
   # {title: params[:post][:title]m contents: [:post][:contents]} 
end
```

``` ruby
wonwon:~/daum_cafe $ rake routes
   Prefix Verb   URI Pattern               Controller#Action
    posts GET    /posts(.:format)          posts#index
          POST   /posts(.:format)          posts#create
 new_post GET    /posts/new(.:format)      posts#new
edit_post GET    /posts/:id/edit(.:format) posts#edit
     post GET    /posts/:id(.:format)      posts#show
          PATCH  /posts/:id(.:format)      posts#update
          PUT    /posts/:id(.:format)      posts#update
          DELETE /posts/:id(.:format)      posts#destroy

show로 가려면 --> post_path(@post)  --id가 필요할 경우에 객체 자체를 넘겨준다.
new로 가려면  --> new_post_path
```



## 댓글

```ruby
$ rails g model comment content post_id:integer
$ rails g controller comments create destroy
```





# 관계

http://guides.rubyonrails.org/association_basics.html

### 1 : N

  - User가 여러개의 글(Post)을 작성할 때
    - post의 속성 중 user_id(외래키)와 자신의 id와 비교를 한다.

### M : N

- User가 여러개의 카페에 가입 가능
- 카페가 여러명의 유저를 받을 수 있음
  - 외래키를 가진다면 1:1관계로만 남을 수 밖에 없으니 중간에 존재할 조인테이블이 필요함
    - 그 안에는 user_id와 daum_id를 가지고 있다. 

``` ruby
$ rails g model daum title
$ rails g model user user_name
$ rails g model membership
```

``` ruby
# 멤버쉽
class CreateMemberships < ActiveRecord::Migration[5.0]
  def change
    create_table :memberships do |t|
      t.integer :user_id
      t.integer :daum_id
      t.timestamps
    end
  end
end

```

### rb파일 

``` ruby
class Membership < ApplicationRecord
    belongs_to :user
    belongs_to :daum
end
---------------------------------------------------------------------------
class Daum < ApplicationRecord
    has_many :memberships
    has_many :users, through: :memberships
end
---------------------------------------------------------------------------
class User < ApplicationRecord
    has_many :memberships
    has_many :daums, through: :memberships
end
```

``` ruby
$ rake db:migrate
$ rails c
2.3.4 :001 > Daum.create(title: "haha")
2.3.4 :002 > Daum.create(title: "haha2")
2.3.4 :003 > User.create(user_name: "hoho")
2.3.4 :004 > User.create(user_name: "hoho2")

```

1번 유저가 1,2,3 카페에 가입한다.

``` ruby
2.3.4 :007 > Membership.create(user_id: 1, daum_id: 1)
2.3.4 :008 > Membership.create(user_id: 1, daum_id: 2)
2.3.4 :009 > Membership.create(user_id: 1, daum_id: 3)

u1.daums = [1번카페, 2번카페, 3번 카페]
```

2번 유저는 2,3 번 카페에 가입한다.

``` ruby
2.3.4 :010 > Membership.create(user_id: 2, daum_id: 2)
2.3.4 :011 > Membership.create(user_id: 2, daum_id: 3)
```

3번 유저는 1,3 번 카페에 가입한다.

``` ruby
2.3.4 :012 > Membership.create(user_id: 3, daum_id: 1)
2.3.4 :013 > Membership.create(user_id: 3, daum_id: 3)
```

``` ruby
2.3.4 :014 > u1 = User.find(1)
2.3.4 :016 > u1.daums
NoMethodError: undefined method `daums' for #<User:0x000000041cd370>
```



``` ruby
2.3.4 :002 > reload!
2.3.4 :004 > u1 = User.find(1)
2.3.4 :005 > u1.daums
  Daum Load (0.2ms)  SELECT "daums".* FROM "daums" INNER JOIN "memberships" ON "daums"."id" = "memberships"."daum_id" WHERE "memberships"."user_id" = ?  [["user_id", 1]]
 => #<ActiveRecord::Associations::CollectionProxy [#<Daum id: 1, title: "haha", created_at: "2018-06-26 06:27:55", updated_at: "2018-06-26 06:27:55">, #<Daum id: 2, title: "haha2", created_at: "2018-06-26 06:28:24", updated_at: "2018-06-26 06:28:24">, #<Daum id: 3, title: "haha3", created_at: "2018-06-26 06:32:44", updated_at: "2018-06-26 06:32:44">]> 
```



================================

1번 카페에는 1,3번 유저가 가입했다.

``` ruby
c1.user = [1번 유저, 3번 유저]
```

2번 카페에는 1,2번 유저가 가입했다.

3번 카페에는 1,2,3번 유저가 가입했다.