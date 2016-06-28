### Running the app

```bash
npm install
meteor --settings config/prod_settings.json
```

On file `config/prod_settings.json` you shoud configure your Goolge credentials for Oauth

```json
  {
    "env": "PROD",
    "google": {
      "id": "xxxxxxxxxxxxxxxxxxxxxxxxx",
      "secret": "xxxxxxxxxxxxxxxxxxx"
    }
  }
```
