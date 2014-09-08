### About
This a simple API that you can call when you make a static website and you need a contact form.
Instead of making a php script or any cgi/fastcgi script, you can use this for free. For the moment you can have following fields in your form: `name`, `email`, `subject`, `message`. Other fields will be ignored.

### Usage
To create an account you have to register with your email address. Your email has to be valid, because you'll get all of your messages there. To register make a post request with your email on `ruby-contactform.herokuapp.com`. You will get a token which is going to be used in your form. DO NOT FORGET YOUR TOKEN!. I will ignore any messages that will ask for lost tokens.

Your token will be passed to action attribute inside form element.

**How to register?**

```
$ curl --data "email=your@emailaddress.com" ruby-contactform.herokuapp.com/user/register
  Your token for your@emailaddress.com is a3484djd-7d2c-4dq1-bs01-9s3861bf1942
```

**Test your token**

```
$ curl --data "name=Jane Doe&email=janedoe@email.com&subject=Hello stranger&message=Lorem ipsum" ruby-contactform.herokuapp.co
m/user/a3484djd-7d2c-4dq1-bs01-9s3861bf1942

Message sent%
```

**From your website**

```
<form action="http://ruby-contactform.herokuapp.com/user/a3484djd-7d2c-4dq1-bs01-9s3861bf1942">
  Name: <input type="text" name="name"><br>
  Email: <input type="text" name="email"><br>
  Subject: <input type="text" name="subject"><br>
  Message: <textarea name="message" cols="20" rows="5"></textarea><br>

  <input type="submit" value="Send!">
</form>
```

### Host on your own server
If you have privacy concerns, you can host this anywhere you like. Please keep in mind that you'll have an open relay. I sugest hosting on a PaaS.

```
$ git clone https://github.com/radubogdan/ruby-contactform.git
$ heroku create
$ heroku config:set REDISTOGO_URL="redis://redistogo:183289ndfjds38283ndfdn93@grouper.redistogo.com:10499/ "
$ heroku config:set MANDRILL_APIKEY=xA-JfjUFJkfjsJFnjZ
$ git push heroku master
```

### License
See the [License](https://raw.githubusercontent.com/radubogdan/ruby-contactform/master/LICENSE?token=2222046__eyJzY29wZSI6IlJhd0Jsb2I6cmFkdWJvZ2Rhbi9ydWJ5LWNvbnRhY3Rmb3JtL21hc3Rlci9MSUNFTlNFIiwiZXhwaXJlcyI6MTQxMDUyMjY3Nn0%3D--5bd8b1e92169c40d433b0f5e08fb434f4379dc5f) file.
