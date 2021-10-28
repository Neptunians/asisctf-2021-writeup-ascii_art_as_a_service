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
<TOKEN>|<SESSION_ID>|<STATUS>
```

While running it locally, I got this example:

```
z4fxc0z9I05ZLgSTxUF4IM3LHV1UnXQR|Tej5L70Hl3d_5nWQGjfzXnMi1IP5HMV2|Processing...
```

* Calls the Linux timeout command, using the jp2a command. 
    * The [timeout](https://man7.org/linux/man-pages/man1/timeout.1.html) command calls other commands with a maximum time restriction. In this case, 2 seconds.
    * The [jp2a](https://github.com/Talinx/jp2a) is the tool which converts the JPG image to ASCII, making the magic happen.
    * The parameter for jp2a is the URL we sent

**There is a weakness here:** We can inject parameters on this command!
The challenge made it easier for us: the URL in the request is already an array, so we can send more than just the URL string.
More on that later.

* After running de jp2a command, it writes the ascii art result in the file (./output/newRandomID).
* Writes the generated file name in the request file:

Format:
```
<TOKEN>|<SESSION_ID>|<OUTPUT FILE NAME>
```

Example:
```
z4fxc0z9I05ZLgSTxUF4IM3LHV1UnXQR|Tej5L70Hl3d_5nWQGjfzXnMi1IP5HMV2|./output/RR0TWIFwIsf6vU3go8cOxuDbrmV1vLFj
```

This finishes the request processing.
It uses this file (later) to know where to find the ascii art.

* In the case of error, it writes "Something bad happened!" in this same status.

### The /request/:ID route

```javascript
app.get("/request/:reqtoken",(req,res)=>{
	const reqToken = req.params.reqtoken
	const reqFilename = `./request/${reqToken}`
	var content
	if(!/^[a-zA-Z0-9]{32}$/.test(reqToken) || !fs.existsSync(reqFilename)) return res.json( { failed: true, result: "bad request token." })

	const [origReqToken,ownerSessid,result] = fs.readFileSync(reqFilename).toString().split("|")

	console.log('ownerSessid: ' + ownerSessid)

	if(req.session.id != ownerSessid) return res.json( { failed: true, result: "Permissions..." })
	if(result[0] != ".") return res.json( { failed: true, result: result })

	try{
		content = fs.readFileSync(result).toString();
		
	} catch(e) {
		console.log("Something bad happened!");
		console.log(e);
		console.log();
		return res.json({ failed: false, result: "Something bad happened!" })
	}

	res.json({ failed: false, result: content })
	res.end()
})
```

#### **Summary**:
* In this route, the app receives the specific token used to receive the ascii art result (the one from the loop we saw at the start).
* It uses the request ID to find the filename with the same ID inside the "request" directory.
* The token is filtered for a RegExp. Only Alphanumeric chars... no path traversal for you.
* It reads and parses the file, which is in the format discussed earlier:

```
<TOKEN>|<SESSION_ID>|<STATUS OR OUTPUT FILE NAME>
```

* It also filters the session ID, to avoid us reading some other user result (no poking in your  friends CTF game).
* It also checks that the file name starts with a ".". If it's not a ".", just send the result (Possibly a status, like "Processing...").
* After all that filtering, it just reads the file and sends to us (hummmmmmmmm).
* If it can't read the file (like when it is still processing), just return the message "Something bad happened!".

When the server just reads some file (without much validation) and sends to us, our minds automatically think on [LFI - Local File Inclusion](https://owasp.org/www-project-web-security-testing-guide/v42/4-Web_Application_Security_Testing/07-Input_Validation_Testing/11.1-Testing_for_Local_File_Inclusion).

![thinking_about_lfi](img/anakin_and_padme_hacking.jpg)

### The rest

```javascript
app.get("/flag",(req,res)=>{
	if(req.ip == "127.0.0.1" || req.ip == "::ffff:127.0.0.1") res.json({ failed: false, result: flag })
	else res.json({ failed: true, result: "Flag is not yours..." })
})

function clearOutput(){
	try{
		childProcess.execSync("rm ./output/* ./request/* 2> /dev/null")
	} catch(e){}
	setTimeout(clearOutput,120e3)
}
```

#### **Summary**:
* This /flag endpoint was useless for my solution, so I'll just ignore it (looking forward for writeups using it!).
* The clearOutput deletes both the request and output files every 2 minutes. It's saving earth resources. #begreen!

## Let's play a game

![riddler](img/batman_riddle.jpg)

So far we got a possible command injection when inserting data.

My first (stupid) try was injecting a pipe and bash commands but.. we're not on bash here. Won't work.

I also thought about injecting parameters on the **timeout** command, to have more options on the Linux side, but it would only work if I could inject before the jp2a. No good.

But we can still put strings after the jp2a.

Let's first play with the original (innocent) command called by the app.

![asis-ascii](img/asis-ascii.png)

(ASCII art is so nice!)

Ok, so let's take a look at jp2a parameters.

I'll just keep the key parts here, for simplicity.
(I investigated some other parameters, without success)

```text
$ jp2a --help
jp2a 1.0.9
Copyright 2006-2016 Christian Stigen Larsen
and 2020 Christoph Raitzig
Distributed under the GNU General Public License (GPL) v2.

Usage: jp2a [ options ] [ file(s) | URL(s) ]

Convert files or URLs from JPEG format to ASCII.

OPTIONS
...
  -d, --debug       Print additional debug information.
...
      --html        Produce strict XHTML 1.0 output.
...
      --html-title=...  Set HTML output title
...
      --output=...  Write output to file.
...

Project homepage on https://github.com/Talinx/jp2a
Report bugs to <chris-r@posteo.net>
```

We send a URL, but we could just send a local file!
At first, I tought the solution would be somehow generating ASCII art from the /flag endpoint, using SSRF but.. the /flag returns only text. I didn't find a way to do it (maybe there is).
I also don't know about any local file that could help. But let's move on.

* The **--html** is interesting: it generates a fixed HTML output with the ASCII image. No direct result so far.
* The **--html-title** is even more interesting: I can put a string from my control here. But even with this controlled HTML, I don't get near the flag.
* The **--output=** is the holy grail. We can save the result ascii file inside the server, on a path of our control!!

But... how this takes us near the Flag?



## References

* ASISCTF: https://asisctf.com/
* CTF Time Event: https://ctftime.org/event/1415
* Linux Timeout Command: https://man7.org/linux/man-pages/man1/timeout.1.html
* jp2a: https://github.com/Talinx/jp2a
* Repo with the artifacts discussed here: https://github.com/Neptunians/asisctf-2021-writeup-ascii_art_as_a_service
* Team: [FireShell](https://fireshellsecurity.team/)
* Team Twitter: [@fireshellst](https://twitter.com/fireshellst)
* Follow me too :) [@NeptunianHacks](twitter.com/NeptunianHacks)