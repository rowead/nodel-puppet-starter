Facter.add(:kiosk) do
  setcode do
    screen = {}
    details = Facter.value(:hostname).split('-')

    if (details.length() == 4 && details[2] == 'PC')
      screen['institution'] = 'wam'
      screen['branch'] = details[0]
      screen['gallery'] = details[1]
      screen['screen'] = details[3]
    end

    if (details.length() == 4 && details[0] == 'wam')
      screen['institution'] = details[0]
      screen['branch'] = details[1]
      screen['gallery'] = details[2]
      screen['screen'] = details[3]
    end

    if (details.length() == 3 && details[1] == 'Nodel')
      screen['institution'] = 'wam'
      screen['branch'] = details[0]
      screen['gallery'] = details[1]
    end

    if File.exists?('/opt/kiosk/telemetry/interactive-type.txt')
        interactive_type = File.read('/opt/kiosk/telemetry/interactive-type.txt')
        screen['type'] = interactive_type
    end
    screen
  end
end