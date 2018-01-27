function [shifted_img, mini, minj] = im_align(a, b, ratio_crop, shift_pts)
    

    [width, height] = size(a);

    ivalues = horzcat(int8(linspace(-width*ratio_crop, -1, shift_pts)), 0, int8(linspace(1, width*ratio_crop, shift_pts)));
    
    jvalues = horzcat(int8(linspace(-height*ratio_crop, -1, shift_pts)), 0, int8(linspace(1, height*ratio_crop, shift_pts)));

    
    min = ssd(a, b, ratio_crop);
    mini = 0;
    minj = 0;

    for i = ivalues
        for j = jvalues
            temp = ssd(a, circshift(b, [i, j]), ratio_crop);
            if temp < min
                min = temp;
                mini = i;
                minj = j;
            end;
        end;
    end;
    
    shifted_img = circshift(b, [mini, minj]);
end
