function dist = find_displacement(a, b, shift_pts)
    
    min = inf;
    
    for i = -shift_pts:shift_pts
        for j = -shift_pts:shift_pts
            
            
            temp = ssd(a, circshift(b, [i, j]));
            if temp < min
                min = temp;
                dist = [i, j];
            end;
        end;
    end;
    
  
end
