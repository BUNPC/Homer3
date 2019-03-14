function SetConfig()

c = ConfigFileClass();
c.SetValue('Regression Test Active','true');
c.SetValue('Include Archived User Functions','Yes');
c.WriteFile();

