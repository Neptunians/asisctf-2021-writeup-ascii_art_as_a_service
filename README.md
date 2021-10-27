# ASISCTF 2021: ASCII art as a service (Web)

![Logo](img/logo.png)

[ASIS CTF](https://asisctf.com/) is a heavyweight CTF happening since 2013. The Rating weight on CTFTime for this event is currently 89.22, which is a hardcore valuation.

The 2021 edition started on October 22, with 24 challenges for several skills.

I can speak for the web challenges, which were incredibly fun!

# The Challenge

 ```"You can convert your images to ASCII art. It is AaaS! 🤣 Go here"```

![The Challenge](img/challenge-main.png)

In this challenge, we are presented with a an **Ascii art as a service** form. It receives a JPG image and converts it to ASC.

It already starts with a sample image URL:

https://images.all-free-download.com/images/graphiclarge/animal_pictures_08_hd_picture_168987.jpg

![The Challenge](img/animal_pictures_08_hd_picture_168987.jpg)

And the result:

![The Challenge](img/ascii-result.png)

(I love ASCII art since mIRC times!)

# First Look - Client-side

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

# References

* ASISCTF: https://asisctf.com/
* CTF Time Event: https://ctftime.org/event/1415
* Repo with the artifacts discussed here: https://github.com/Neptunians/asisctf-2021-writeup-ascii_art_as_a_service
* Team: [FireShell](https://fireshellsecurity.team/)
* Team Twitter: [@fireshellst](https://twitter.com/fireshellst)
* Follow me too :) [@NeptunianHacks](twitter.com/NeptunianHacks)