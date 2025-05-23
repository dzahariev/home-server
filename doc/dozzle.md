## Dozzle settings

Generate users credential file with:

```
docker run -it --rm amir20/dozzle generate admin --password mysecrethere --email me@mymail.com --name "John Doe"  > users.yml
```

Store this file in `${DATA_DIR}/dozzle` folder