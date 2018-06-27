# DAY 9

## 퀴즈

- M : N 관계의 예시 5가지 이상 적어보기
  - 책 - 서점
  - 쇼핑몰 - 상품
  - 교수 - 학생 (수업 - 학생)
  - 의사 - 환자
  - 상품 - 사람
  - 나비 - 꽃
  - 좋아요 - 사람 (별점 - 사람) (카테고리 , 해쉬태그)
  - 사람 - 카페

  ### M:N Relation 설정하기

  - 바로 어제 다대다 관계를 설정했는데, 실제 코드에는 적용해보지 않았다. 카페를 개설하는 과정에서 개설한 사람의 user_name이 자동으로 카페의 master_name에 들어가고 해당 유저가 카페에 가입하는 로직을 추가해보자.

  *app/controllers/cafes_controller.rb*

  ```
  ...
      def create
          @cafe = Daum.new(daum_params)
          @cafe.master_name = current_user.user_name
          if @cafe.save
              Membership.create(daum_id: @cafe.id, user_id: current_user.id)
              redirect_to cafe_path(@cafe), flash: {success: "카페가 개설되었습니다."}
          else
              redirect_to :back, flash: {danger: "카페 개설에 실패했습니다."}
          end
      end
  ...
  ```

  - *cafe*와 *user*의 관계를 설정하는 *join table*인 *membership* 테이블에 양쪽의 id를 각각 넣어서 관계를 추가한다. 이제 카페를 개설하고 개설한 사람의 이름이 이 카페의 주인 이름으로 저장되고, 자동으로 가입된다.

### bcrypt

- 그동안 로그인, 회원가입 시에 비밀번호는 일반 문자열로 저장되었었다. 하지만 일반 사이트에서 비밀번호를 평범한 문자열로 저장하는 것은 있을 수 없는 일이다. 간단한 `bcrypt` 잼을 이용하여 비밀번호를 암호화하여 저장하고 로그인 시 복호화하여 사용하는 방법을 배워보자.

*Gemfile*

```
gem 'bcrypt'
```

```
$ bundle install
```

*app/models/user.rb*

```
class User < ApplicationRecord
	has_secure_password    
...
```

- 기본적인 설정은 끝났지만 비밀번호를 받아 암호화하여 저장할 컬럼 설정이 필요하다.

*db/migrate/create_user.rb*

```
class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :user_name
      t.string :password_digest

      t.timestamps
    end
  end
end
```

- `password_digest` 컬럼은 암호화된 문자열을 저장할 것이다. 우리는 다음과 같은 방식으로 유저 정보를 저장하면 된다.

```
$ rails c
> User.create(user_name: "haha", password: "1234", password_confirmation: "1234")
#<User id: 2, user_name: "haha", password_digest: "$2a$10$MiTBq98.kTrcuV3CrIZ3FOdpST92k33A6s0u.IVOU4X...", created_at: "2018-06-27 08:08:34", updated_at: "2018-06-27 08:08:34"> 
```

- 결과적으로 암호화된 문자열이 저장될 것이다.

## Gem

https://github.com/plataformatec/devise --- 로그인 구현

``` ruby
$ rake db :drop
```

`Gemfile` 에서 `gem 'bcrypt', '~> 3.1.7'`의 주석을 제거하고 저장

`20180626061815_create_users.rb` 에  `t.string :password_digest` 코드 추가

`user.rb`에 `has_secure_password` 코드를 삽입

``` ruby
$ rake db:migrate
$ rails c
Running via Spring preloader in process 10528
Loading development environment (Rails 5.0.7)
2.3.4 :001 > User.create(user_name: "haha", password: "12341234")
   (0.2ms)  begin transaction
  SQL (0.5ms)  INSERT INTO "users" ("user_name", "password_digest", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["user_name", "haha"], ["password_digest", "$2a$10$yInvHOwCBEai4C.NJI8hkOd97ITsck26OyeuHZsLPCU1Ja5od7SCC"], ["created_at", "2018-06-27 00:47:53.321496"], ["updated_at", "2018-06-27 00:47:53.321496"]]
   (12.4ms)  commit transaction
 => #<User id: 1, user_name: "haha", password_digest: "$2a$10$yInvHOwCBEai4C.NJI8hkOd97ITsck26OyeuHZsLPCU...", created_at: "2018-06-2  00:47:53", updated_at: "2018-06-27 00:47:53"> 
      
2.3.4 :002 > u = User.find_by_user_name("haha")
  User Load (0.5ms)  SELECT  "users".* FROM "users" WHERE "users"."user_name" = ? LIMIT ?  [["user_name", "haha"], ["LIMIT", 1]]
 => #<User id: 1, user_name: "haha", password_digest: "$2a$10$yInvHOwCBEai4C.NJI8hkOd97ITsck26OyeuHZsLPCU...", created_at: "2018-06-27 00:47:53", updated_at: "2018-06-27 00:47:53"> 
2.3.4 :003 > u.password.eql?("12341234")
 => false 
2.3.4 :004 > u.authenticate("12341234")
 => #<User id: 1, user_name: "haha", password_digest: "$2a$10$yInvHOwCBEai4C.NJI8hkOd97ITsck26OyeuHZsLPCU...", created_at: "2018-06-27 00:47:53", updated_at: "2018-06-27 00:47:53"> 
2.3.4 :005 > u.authenticate("1234123")
 => false       
```



- AuthenticateController 작성
- ApplicationController에서 유저와 관련된 메소드 작성
- CafesController에서 카페와 관련된 메소드 작성
- 각각의 조건에 맞춰서 로직 수정



``` ruby
$ rails g controller authenticate
$ rake db:drop
```

`2018~daum.rb`에 `t.text :description`추가

``` ruby
$ rails g controller cafes
```

`routes.rb`

``` ruby
  #authenticate
  get '/sign_up' => 'authenticate#sign_up'
  post '/sign_up' => 'authenticate#user_sign_up'
  get '/sign_in' => 'authenticate#sign_in'
  post '/sign_in' => 'authenticate#user_sign_in'
  delete '/sign_out' => 'authenticate#sign_out'
  get '/user_info/:user_name' => 'authenticate#user_info'
```





`authenticate_controller.rb`

```ruby
def sign_in
end

def user_sign_in
    @user = User.find_by(user_name: params[:user_name])
    if @user.present?and @user.authenticate(params[:password])
       redirect_to root_path, flash: {alert:'로그인 성공'}
    else
        redirect_to :back, flash: {errors:'로그인 정보를 확인하세요'}
```

`views/authenticate/sign_in.html.erb`:뒤에 url이 없는 경우는 route파일 시에 같은 파일명으로 해놨기 때문에 명시하지 않아도 됨.

```erb
<h1>로그인</h1>
<%= form_tag do %>
	<%= text_field_tag :user_name %><br><br>
	<%= password_field_tag :password %><br><br>
	<%= submit_tag 'Sign In' %>
<% end %> 
```

`rake routes`

```ruby
          Prefix Verb   URI Pattern                          Controller#Action
         sign_up GET    /sign_up(.:format)                   authenticate#sign_up
                 POST   /sign_up(.:format)                   authenticate#user_sign_up
         sign_in GET    /sign_in(.:format)                   authenticate#sign_in
                 POST   /sign_in(.:format)                   authenticate#user_sign_in
        sign_out DELETE /sign_out(.:format)                  authenticate#sign_out
                 GET    /user_info/:user_name(.:format)      authenticate#user_info
                 POST   /posts/:id/comments/create(.:format) comments#create
                 DELETE /comments/:id(.:format)              comments#destroy
comments_destroy GET    /comments/destroy(.:format)          comments#destroy
           posts GET    /posts(.:format)                     posts#index
                 POST   /posts(.:format)                     posts#create
        new_post GET    /posts/new(.:format)                 posts#new
       edit_post GET    /posts/:id/edit(.:format)            posts#edit
            post GET    /posts/:id(.:format)                 posts#show
                 PATCH  /posts/:id(.:format)                 posts#update
                 PUT    /posts/:id(.:format)                 posts#update
                 DELETE /posts/:id(.:format)                 posts#destroy
            root GET    /                                    posts#index
        rails_db        /rails/db                            RailsDb::Engine
```

### cafe controller

* 카페 만들기 

* master name column에 현재 user_name을 넣는다.
* 뒤에 유동적인 id가 들어갈 경우, prefix가 생기지 않는다.
* 강제로 routes.rb에  as: 'join_cafe'라는 패스를 새로 설정해줄 수 있다.

```ruby
    join_cafe POST   /join_cafe/:cafe_id(.:format)        cafes#join_cafe
```



```ruby
          Prefix Verb   URI Pattern                          Controller#Action
           cafes GET    /cafes(.:format)                     cafes#index
                 POST   /cafes(.:format)                     cafes#create
        new_cafe GET    /cafes/new(.:format)                 cafes#new
       edit_cafe GET    /cafes/:id/edit(.:format)            cafes#edit
            cafe GET    /cafes/:id(.:format)                 cafes#show
                 PATCH  /cafes/:id(.:format)                 cafes#update
                 PUT    /cafes/:id(.:format)                 cafes#update
                 POST   /join_cafe/:cafe_id(.:format)        cafes#join_cafe
            root GET    /                                    cafes#index
        rails_db        /rails/db                            RailsDb::Engine

```

`redirect_to posts_url`

=>       Prefix가 posts인 곳으로 간다.

 posts   GET    /posts(.:format)                     posts#index            

​	      POST   /posts(.:format)                     posts#create



* template missing error 는 view파일이 없을 때 나온다.

`index.html.erb`

```erb
<h1>다음 카페에 오신것을 환영합니다.</h1>

<div class="list-group">
    <% @cafes.each do |cafe| %>
      <%= link_to cafe.title, cafe_path(cafe), class: "list-group-item list-group-item-action" %>
    <% end %>
</div>
<div class="text-center">
    <%= link_to "카페개설하기",new_cafe_path(), class: "btn btn-primary" %>
</div>
```

```erb
<h1>다음카페에 오신 것을 환영합니다.</h1>
<div class="list-group">
  <% @cafes.each do |cafe| %>

      <%= link_to cafe.title,cafe_path(cafe),class: "list-group-item list-group-item-action" %>
  <% end %>
</div>
<br><br>
<div class="text-center">
    <%= link_to '카페 개설하기',new_cafe_path,class: 'btn btn-success' %>
</div>
```

### 기타

```ruby
  def new
	@post = Post.new
  end
```

* form_for는 꼭 new action에서 Post.new를 해줘야 함.
* html <form action> url , method 의 기본값은 GET
* rails <form_tag> url, method의 기본값을 POST
* rails <form_for 모델명> url, method의 기본값은 POST 

=>해당 모델 post가 Post.new -> create로 , Post.find ->update액션으로 간다. 

### form_for 의 조건

- scaffold를 배우면서 처음 `form_for`를 접하고 잘 이해가 안가는 부분이 많을 것이다. `form_for`를 이해하기 위해서는 기본적으로 model + controller 라는 것을 생각해야 한다. 단순히 form을 만들고 input을 우리가 원하는 이름으로 지정했다면, `form_for`는 model에서 테이블에 설정된 컬럼에 맞춰서 사용한다고 생각해야 한다. input 태그의 타입이 어떤 것이든 상관없다. 하지만 반드시 `form_for` 의 매개변수로 설정된 변수(모델의 인스턴스)와 관련된 모델의 컬럼이 존재해야한다.(*value 속성을 주는 경우는 제외*)

```
<%= form_for(Cafe.new) do |f| %>
	<%= f.text_field :title %>
    <%= f.text_area :description %>
<% end %>
```

- `Cafe` 모델에 새로운 데이터를 추가하는 `form_for`이다. 아마도 title, description 컬럼을 가지고 있는 것으로 예상할 수 있다.
- `form_for`는 또한 controller 이름, route와도 연관이 있다. `form_for`를 사용할 경우 기본적으로 routes.rb에서 `resources`를 사용한 것으로 간주하고 매개변수로 사용하는 모델의 이름과 관련된 route를 자동으로 만들어 버린다. 만약에 모델명은 `daum`, 컨트롤러명은 `cafe`로 했다면 `form_for`를 사용하는 것이 적절하지 않다.

