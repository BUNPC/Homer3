function result = islinux()

% We want to distinguish between MAC and Unix
% which is what this function does

result = ~strncmp(computer,'PC',2) & ~strncmp(computer,'MAC',3);

