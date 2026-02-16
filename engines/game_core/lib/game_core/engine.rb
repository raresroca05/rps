# frozen_string_literal: true

module GameCore
  class Engine < ::Rails::Engine
    isolate_namespace GameCore

    config.generators do |g|
      g.test_framework :rspec
    end

    # Eager load domain classes in production
    config.eager_load_paths << root.join("app", "models")
  end
end
