SimpleConf
=============

Needed a simple configuration library for my gems. Made public so everyone can take advantage!

##Install
    [sudo] gem install simpleconf

##Usage

  **Simple Configuration**

    CONFIG = SimpleConf {
        host "localhost"
        port 80
        blacklist [1,2,3]
    }

    CONFIG.host # localhost
    CONFIG.port # 80
    CONFIG.blacklist # [1,2,3]

  **Nested Configuration**

    CONFIG = SimpleConf {
      server {
        ip "0.0.0.0"
        port 8080
      }

      workers 50

      security {
        admin {
          only_from "127.0.0.1"
        }

        max_logins 5
      }
    }

    CONFIG.server.ip # "0.0.0.0"
    CONFIG.workers # 50
    CONFIG.security.admin.only_from # "127.0.0.1"
    CONFIG.security.max_logins # 5

  **Merging**

    default = SimpleConf {
      host "localhost"
      port 80
    }

    new_config = default.merge( #also merge!
      SimpleConf {
        port 9999
      }
    )

    new_config.host # "localhost"
    new_config.port # 9999

  **Overriding**

    config = SimpleConf {
      host "localhost", :override => false
      port 80
    }

    config.host "google.com"
    config.host # Still "localhost"
    config.port 9999
    config.port # 9999

  **Lock configuration**

    default = SimpleConf(:init_only => true){
      host "localhost"
    }

    default.port 80 #throws error!!!

  **File Configuration**

    # basic.conf

    server "localhost"
    ports [80, 8080, 3000]
    auth {
      user "mike"
      pass "password"
    }

    # code.rb

    conf = SimpleConf.load("basic.conf")
    conf.server # localhost
    conf.ports # [80, 8080, 3000]
    conf.auth.user # mike
    # etc


  To see all examples/cases, see the spec file.
