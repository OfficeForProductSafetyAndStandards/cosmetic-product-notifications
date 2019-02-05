# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :redis_store,
                                       servers: Rails.application.config_for(:redis_session),
                                       key: "_mspsds_session"
