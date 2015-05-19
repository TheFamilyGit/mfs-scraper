# MFS Startup & Founder Scrapping

## Requirements

**Warning**: you must have meteor installed on your machine.

```bash
curl https://install.meteor.com/ | sh
```

## Launching The MFS Scrapping App


Go to the app directory, and launch meteor:

```bash
cd mfs/
meteor
```

Query to display the results:

```bash
meteor mongo
> db.founders.find({ linkedin: { $exists: true} }, {_id: 0, url: 0 }).forEach(function(f){print(tojson(f, '', true));});
```
