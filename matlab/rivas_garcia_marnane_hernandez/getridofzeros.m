function y = getridofzeros(x)

for (i=1:length(x))
        if(x(i))
                y(i) = x(i);
        else
                break
        end

end
