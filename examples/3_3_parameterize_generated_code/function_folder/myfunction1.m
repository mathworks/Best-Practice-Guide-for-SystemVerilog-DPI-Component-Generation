% Copyright 2024 The MathWorks, Inc

function [out, out2, out3, out4] = myfunction1(ctrl_reg, ...
    data1, data2, data3, data4, data5, data6, data7, ...
    ctrl_reg2, data8)
    tmp = 0;
    if ctrl_reg.valid1 
        tmp = data1 + data2.one;
    else 
        if ctrl_reg.valid2
            tmp = data1 - data2.one + data2.two;
        else
            tmp = data1 - data2.two;
        end
    end
    out = foo(tmp);
    out2 = data3 + data4;
    if ctrl_reg2>1
        out3 = data5 - data6;
    else
        out3 = data5+data6;
    end
    if data8
        out4 = sum(data7);
    else
        out4 = prod(data7);
    end
end