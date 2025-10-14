source "https://rubygems.org"

# fastlane 本体（Windows でも Android 用 lane は動作可能）
gem "fastlane", "~> 2.228"

# Ruby 3.4+ で標準から外れたライブラリを補う
gem "abbrev", "~> 0.1"
gem "fiddle", "~> 1.1"

# Ruby 3.5+ でデフォルト gem から外れるため、警告抑制と将来互換のため追加
gem "ostruct"

# iOS は現状非対応だが、依存で参照されることがあるため念のため
gem "xcodeproj", "~> 1.24", platforms: [:ruby]

# To install:
#   bundle install
# To run lanes via bundler:
#   bundle exec fastlane android apk
