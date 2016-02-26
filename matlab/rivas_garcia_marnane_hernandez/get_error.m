function[err] = get_error(y,yy)

if (length(y) != length(yy))
        break
end

err = zeros(1,length(y));
for (i = 1: length(y))
        if(yy(i))
                err(i)=(yy(i)-y(i))/y(i);
        else
                err(i) = -y(i);
        end

end
