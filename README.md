### About

Simple API that you can call when you make a static website and you need a contact form.

Fiels:

- name
- email
- subject
- message

### Usage (2 steps)

#### 1. Register your email

```
$ curl --data "email=your@emailaddress.com" ruby-contactform.herokuapp.com/user/register
{"status":200,"message":"a3484djd-7d2c-4dq1-bs01-9s3861bf1942"}
```

**Test your token**

```
$ curl --data "name=Jane Doe&email=janedoe@email.com&subject=Hello stranger&message=Lorem ipsum" ruby-contactform.herokuapp.com/user/a3484djd-7d2c-4dq1-bs01-9s3861bf1942
{"status":200,"message":"success"}
```

#### 2. Edit `action` in your form.

```
<form method="POST" action="http://ruby-contactform.herokuapp.com/user/a3484djd-7d2c-4dq1-bs01-9s3861bf1942">
  Name: <input type="text" name="name"><br>
  Email: <input type="text" name="email"><br>
  Subject: <input type="text" name="subject"><br>
  Message: <textarea name="message" cols="20" rows="5"></textarea><br>

  <input type="submit" value="Send!">
</form>
```

### Host on your own server

Feel free to host it on your own server. Simple as below.

Example heroku:

```
$ git clone https://github.com/radubogdan/ruby-contactform.git
$ heroku create
$ heroku config:set REDISTOGO_URL="redis://redistogo:183289ndfjds38283ndfdn93@grouper.redistogo.com:10499/"
$ heroku config:set SENDGRID_API_KEY=xA-JfjUFJkfjsJFnjZ
$ git push heroku master
```

### License
See the [License](https://raw.githubusercontent.com/radubogdan/ruby-contactform/master/LICENSE?token=2222046__eyJzY29wZSI6IlJhd0Jsb2I6cmFkdWJvZ2Rhbi9ydWJ5LWNvbnRhY3Rmb3JtL21hc3Rlci9MSUNFTlNFIiwiZXhwaXJlcyI6MTQxMDUyMjY3Nn0%3D--5bd8b1e92169c40d433b0f5e08fb434f4379dc5f) file.
