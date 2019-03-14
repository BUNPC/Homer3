function ResetConfig()

c = ConfigFileClass();
c.SetValue('Regression Test Active','false');
c.SetValue('Include Archived User Functions','No');
c.WriteFile();
