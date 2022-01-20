function cfg = InitConfig(cfg)
if ~exist('cfg','var') || isempty(cfg)
    cfg = ConfigFileClass();
elseif ~isa(cfg, 'ConfigFileClass')
    cfg = ConfigFileClass();
end
