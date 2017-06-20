function bContain = contains(q, value)

bContain = false;
if ~isempty(find(q==value))
    bContain = true;
end

end

