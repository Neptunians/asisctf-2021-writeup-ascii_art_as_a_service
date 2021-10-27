# ASISCTF 2021: ASCII art as a service (Web)

![Logo](img/logo.png)

[ASIS CTF](https://asisctf.com/) is a heavyweight CTF happening since 2013. The Rating weight on CTFTime for this event is currently 89.22, which is a hardcore valuation.

The 2021 edition started on October 22, with 24 challenges for several skills.

I can speak for the web challenges, which were incredibly fun!

## The Challenge

 ```"You can convert your images to ASCII art. It is AaaS! 🤣 Go here"```

![The Challenge](img/challenge-main.png)

In this challenge, we are presented with a an **Ascii art as a service** form. It receives a JPG image and converts it to ASC.

It already starts with a sample image URL:

https://images.all-free-download.com/images/graphiclarge/animal_pictures_08_hd_picture_168987.jpg

![The Challenge](img/animal_pictures_08_hd_picture_168987.jpg)

And the result:

![The Challenge](img/ascii-result.png)

(I love ASCII art since mIRC times!)

## First Look - Client-side

It starts with a POST to **/request** endpoint with a simple JSON Payload containing the image URL:

```json
{"url":["https://images.all-free-download.com/images/graphiclarge/animal_pictures_08_hd_picture_168987.jpg"]}
```

![The Challenge](img/POST_image_url.png)

It then redirects us to **/request/Hulq94c45UO19c7RHWXpJFxpAhbPZzMw**. This obviously random ID is the identifier of my request.

At first it receives an **"Processing..."** JSON response:

```json
{"failed":true,"result":"Processing..."}
```

The Javascript handler for the request then keeps requesting the same URL until it receives the response with the ASCII data.

```json
{"failed":false,"result":"MMMMMMMMMMMMMMWKxodkX..a-lot-of-stuff-here..NWWM\n"}
```

## Source Code Analysis

We receive the source code for the app. All of the server code is in index.js.

Let's break it in smaller pieces.

### App Setup

```javascript
const express = require('express')
const childProcess = require('child_process')
const expressSession = require('express-session')
const fs = require('fs')
const crypto = require('crypto')
const app = express()
const flag = process.env.FLAG || process.exit()
const genRequestToken = () => Array(32).fill().map(()=>"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".charAt(Math.random()*62)).join("")

app.use(express.static("./static"))
app.use(expressSession({
	secret: crypto.randomBytes(32).toString("base64"),
	resave: false,
	saveUninitialized: true,
	cookie: { secure: false, sameSite: 'Lax' }
}))
app.use(express.json())
```

#### **Summary**:
* Uses the NodeJS Express Framework (we already knew it from the response)
* Gets the Flag from the Environment Variable
* Declares a **genRequestToken**, which generates the random ID we saw earlier.
* Declares the session configuration (not useful for our solving purposes)

### The /request route

```javascript
app.post('/request',(req,res)=>{
	const url = req.body.url
	const reqToken = genRequestToken()
	const reqFileName = `./request/${reqToken}`
	const outputFileName = `./output/${genRequestToken()}`

	fs.writeFileSync(reqFileName,[reqToken,req.session.id,"Processing..."].join('|'))
	setTimeout(()=>{
		try{
			const output = childProcess.execFileSync("timeout",["2","jp2a",...url])
			fs.writeFileSync(outputFileName,output.toString())
			fs.writeFileSync(reqFileName,[reqToken,req.session.id,outputFileName].join('|'))
		} catch(e){
			console.log(e);
			fs.writeFileSync(reqFileName,[reqToken,req.session.id,"Something bad happened!"].join('|'))
		}
	},2000)
	res.redirect(`/request/${reqToken}`)
})
```

#### **Summary**:
* Gets the url from the JSON body
* Generates then random token for our request
* Declares a Request and an Output File Name
* Writes the **Processing...** status

This is important: it saves our request in a file, with the token name in the format:

```
<TOKEN>|<SESSION_ID>|<STATUS OR FILENAME>
```

While running it locally, I got this example:

```
z4fxc0z9I05ZLgSTxUF4IM3LHV1UnXQR|Tej5L70Hl3d_5nWQGjfzXnMi1IP5HMV2|Processing...
```

And after finishing the processing:

```
z4fxc0z9I05ZLgSTxUF4IM3LHV1UnXQR|Tej5L70Hl3d_5nWQGjfzXnMi1IP5HMV2|./output/RR0TWIFwIsf6vU3go8cOxuDbrmV1vLFj
```

More on this in next steps.

* Calls the Linux timeout command, using the jp2a command. 
    * The [timeout](https://man7.org/linux/man-pages/man1/timeout.1.html) command calls other commands with a maximum time restriction. In this case, 2 seconds.
    * The jp2a is the tool which converts the JPG image to ASCII, making the magic happen.


## References

* ASISCTF: https://asisctf.com/
* CTF Time Event: https://ctftime.org/event/1415
* Linux Timeout Command: https://man7.org/linux/man-pages/man1/timeout.1.html
* 
* Repo with the artifacts discussed here: https://github.com/Neptunians/asisctf-2021-writeup-ascii_art_as_a_service
* Team: [FireShell](https://fireshellsecurity.team/)
* Team Twitter: [@fireshellst](https://twitter.com/fireshellst)
* Follow me too :) [@NeptunianHacks](twitter.com/NeptunianHacks)