function [q, value] = poll(q, bHead)

if nargin < 2
    bHead = true;
end

if bHead
    value = q(1);
    q(1) = [];
else
    value = q(end);
    q(end) = [];
end

end

