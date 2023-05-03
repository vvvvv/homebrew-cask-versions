cask "wezterm-nightly" do
  version :latest
  sha256 :no_check

  url "https://github.com/wez/wezterm/releases/download/nightly/WezTerm-macos-nightly.zip",
      verified: "github.com/wez/wezterm/"
  name "WezTerm"
  desc "GPU-accelerated cross-platform terminal emulator and multiplexer"
  homepage "https://wezfurlong.org/wezterm/"

  conflicts_with cask: "wezterm"

  livecheck do
    url "https://github.com/wez/wezterm/releases/download/nightly/WezTerm-macos-nightly.zip"
    strategy :header_match do |headers|
      # matches last-modified header syntax
      regex = /(\w{3}, )?(\d{1,2}) (\w{3}) (\d{4}) (\d{2}):(\d{2}):(\d{2}) GMT/
      match = headers["last-modified"].match(regex)
      if match.nil?
        match = headers["x-ms-creation-time"].match(regex)
      end

      year = match[4]
      month_idx = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"].index {|month| month == match[3].downcase}
      month = (month ? month + 1 : 0).to_s.rjust(2,"0")
      day = match[2].rjust(2, '0')
      hour = match[5].rjust(2, '0')
      minute = match[6].rjust(2, '0')
      second = match[7].rjust(2, '0')
      "#{year}#{month}#{day}#{hour}#{minute}#{second}"
    end
  end

  app "WezTerm.app"

  %w[
    wezterm
    wezterm-gui
    wezterm-mux-server
    strip-ansi-escapes
  ].each do |tool|
    binary "#{appdir}/WezTerm.app/Contents/MacOS/#{tool}"
  end

  preflight do
    # Move "WezTerm-macos-#{version}/WezTerm.app" out of the subfolder
    staged_subfolder = staged_path.glob(["WezTerm-*", "wezterm-*"]).first
    if staged_subfolder
      FileUtils.mv(staged_subfolder/"WezTerm.app", staged_path)
      FileUtils.rm_rf(staged_subfolder)
    end
  end

  zap trash: "~/Library/Saved Application State/com.github.wez.wezterm.savedState"
end
