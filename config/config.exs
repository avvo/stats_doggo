use Mix.Config

if File.regular?("config/#{Mix.env()}.exs") do
  import_config "#{Mix.env()}.exs"
end
