function bool = is_int(a)

if is_real_scalar(a)
    bool = (a == round(a));
else
    bool = 0;
end