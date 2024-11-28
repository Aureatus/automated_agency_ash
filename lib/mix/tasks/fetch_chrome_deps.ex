defmodule Mix.Tasks.FetchChromeDeps do
  use Mix.Task

  @chrome_driver %{
    url:
      "https://storage.googleapis.com/chrome-for-testing-public/129.0.6668.100/linux64/chromedriver-linux64.zip",
    dir: "priv/chrome/chromedriver-linux64.zip"
  }

  @chrome_headless %{
    url:
      "https://storage.googleapis.com/chrome-for-testing-public/129.0.6668.100/linux64/chrome-headless-shell-linux64.zip",
    dir: "priv/chrome/chrome-headless-shell-linux64.zip"
  }
  def run(_) do
    [@chrome_driver, @chrome_headless]
    |> Enum.map(fn item ->
      File.mkdir("#{File.cwd!()}/priv/chrome")

      System.cmd("curl", [
        item.url,
        "-o",
        item.dir
      ])

      System.cmd("unzip", [
        "-d",
        "priv/chrome/",
        item.dir
      ])

      System.cmd("rm", [
        "-f",
        item.dir
      ])
    end)
  end
end
