require 'houston'

# Environment variables are automatically read, or can be overridden by any specified options. You can also
# conveniently use `Houston::Client.development` or `Houston::Client.production`.
APN = Houston::Client.development
APN.certificate = File.read("apple_push_notification.pem")

# An example of the token sent back when a device registers for notifications
token = "<8077727b b0e57424 33c288a6 fd6a31a7 745f0c02 fbd297c1 8acbe2fe ce2898c1>"

# Create a notification that alerts a message to the user, plays a sound, and sets the badge on the app
notification = Houston::Notification.new(device: token)
notification.alert = "Hello, World!"

# Notifications can also change the badge count, have a custom sound, have a category identifier, indicate available Newsstand content, or pass along arbitrary data.
notification.badge = 57
notification.sound = "default"
# notification.category = "INVITE_CATEGORY"
notification.content_available = true
# notification.custom_data = {foo: "bar"}

# And... sent! That's all it takes.
APN.push(notification)