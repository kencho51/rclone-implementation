# RClone Implementation
Documentation for implementing RClone in Tencent Cloud in product backlog [#600](https://github.com/gigascience/gigadb-website/issues/600).

### Important documents
1. GigaDB Backup Transition Plan [here](https://docs.google.com/document/d/1IzM-FkFC5xTQQIsWHWiQmzPFELiWP6Ud1tNuOznc7qo/edit#heading=h.g6xlputqtuim)
2. GigaDB Backup Procedure [here](https://docs.google.com/document/d/1YkiEGdB7gd7wkRZQpFKWPZ2yIxvN4K4GSamd13JxOg0/edit#heading=h.pfibwdizyks3)

### Steps
1. Check VPN access  
    - Log in `GlobalProtect` using BGI username and password.
    - Input `OTP`
2. Log in `smoc` account using BGI username and password, [link](https://smoc.genomics.cn/shterm/login) 
    - Scan the QR code using an Authenticator, like `Google Authenticator` for the first time    
    - Enter the code provided by the Authenticator
    - Download and install `AccessClient` tool locally
    - `xattr -rd com.apple.quarantine <app>` to grant the permission to open  