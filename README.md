<!-- 🚀 Thank you for contributing! --->

### Describe the bug

Running `docker-compose build` and then `docker-compose up -d` for an APNS only Vapor project doesn't see tables in Postgres. Running from Xcode and running only database in Docker works.

### To Reproduce

1. Download the [test project files](https://github.com/markbattistella/VaporAPNS) 
1. Run the WebService Vapor package - `Vapor-WebService`
1. In the WebService: 
  1. Edit the WebService to be your `key:`, `keyIdentifier:`, `teamIdentifier:` (lines 33-35 of configure.swift)
  1. Edit the WebService `topic` (line 39 of configure.swift) to the Bundle ID of the PushNotifications project (change it to a custom one you own)
  1. Edit the `APNSKeys` enum with your `p8` file
1. In terminal run `docker-compose up -d db` for the WebService
1. Run the Vapor Xcode project and accept the terminal use
1. Open the demo iOS app - `iOS-PushNotifications`
1. Edit the AppDelegate.swift file to change the IP address to your local machine
1. Run the demo app on a device and accept the permissions for notifications
1. Use a HTTP POST application (Postman / PAW) to send a notification to: `POST http://xxx.xxx.xxx.xxx:8080/token/notify`

Alert message on the iOS screen ✅ 

1. Stop the Xcode Vapor project
1. Stop the Docker database
1. From terminal run the command for the Vapor directory: `docker-compose build`
1. Once built, load the containers: `docker-compose up -d`
1. You should have the app and database running from Docker
1. Quit the iOS app (swipe up)
1. Relaunch the iOS app to register the APNS and database
1. Use a HTTP POST application (Postman / PAW) to send a notification to: `POST http://xxx.xxx.xxx.xxx:8080/token/notify`

Alert message does not appear on screen ❎ 

This also occurs when deploying to Heroku.

### Expected behavior

Expected that building the Vapor project into a container and running it from Docker would result in the same as running it from Xcode directly.

### Environment

* Vapor Framework version: 4.54.0
* Vapor Toolbox version: 18.3.3
* OS version: 12.1

### Additional context

When running it sometimes pops up with this in the Docker logs:

```
app_1 | [ WARNING ] server: relation "tokens" does not exist (parserOpenTable) 
[request-id: 17704098-65F0-496A-9B9F-2566CAF15E30] 
(Vapor/Middleware/ErrorMiddleware.swift:42)
```

But manually starting them database, waiting, then app still no notifications.
