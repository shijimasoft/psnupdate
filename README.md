# PSNUPDATE

*Retrieve PS3 game updates **.pkg** from PSN server with a simple JSON API*

## Host your own API

1. **Install PSNUPDATE dependencies**

```sh
cd psnupdate/
# install nokogiri and sinatra
bundle install
```

2. **Start the API**

`sudo ruby main.rb` (sudo is required to listen port 80)

port setting can be changed editing **main.rb**

```ruby
set :port, 80
```

## API usage

**GET request example:**

```sh
curl localhost/NPJB00769 -H "Accept: application/json"
```

**API response:**
```json
{
   "title_id":"NPJB00769",
   "title":"ペルソナ５",
   "updates":[
      {
         "version":1.01,
         "min_firmware":4.75,
         "size_mb":319.57,
         "url":"http://b0.ww.np.dl.playstation.net/..pkg",
         "sha1":"80a7e6a5dd506072ebdb53ffe7ce261bdcc0483a"
      },
      {
         "version":1.02,
         "min_firmware":4.75,
         "size_mb":16.71,
         "url":"http://b0.ww.np.dl.playstation.net/..pkg",
         "sha1":"34cdced44b858fb405ca4d442582b643da9a8b92"
      },
      {
         "version":1.03,
         "min_firmware":4.75,
         "size_mb":16.75,
         "url":"http://b0.ww.np.dl.playstation.net/..pkg",
         "sha1":"f6caa05550820a365aab89ddb5f4da53dfb72bd2"
      }
   ]
}
```

**GET the newest update**

```sh
curl localhost/NPJB00769/newest -H "Accept: application/json"
```

**API response:**
```json
{
   "title_id":"NPJB00769",
   "title":"ペルソナ５",
   "updates": {
      "version":1.03,
      "min_firmware":4.75,
      "size_mb":16.75,
      "url":"http://b0.ww.np.dl.playstation.net/..pkg",
      "sha1":"f6caa05550820a365aab89ddb5f4da53dfb72bd2"
   }
}
```
