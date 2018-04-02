function singleViewMetrology

    %input = imread('CSL.jpg', 'jpg');
    input = imread('CSL.jpg', 'jpg');

    % Vanishing Points
    vp_1 = [-202 215 1]';
    vp_2 = [1371 230 1]';
    vp_3 = [503 4867 1]';
    
    figure; imshow(input);
    %imagesc(input);
    hold on;
    plot(vp_1(1), vp_1(2), 'r*');
    plot(vp_2(1), vp_2(2), 'g*');
    plot(vp_3(1), vp_3(2), 'b*');
    imshow(input);
    
    figure(2);
    imagesc(input);
    hold on;
    plot([vp_1(1) vp_2(1)], [vp_1(2) vp_2(2)]);
    axis image;

    horizon = real(cross(vp_1', vp_2'));

    length = sqrt(horizon(1)^2 + horizon(2)^2);
    horizon = horizon/length;

    %camera calibration
    syms u v;
    [u_sol, v_sol] = solve(...
                        -u*(vp_2(1)+vp_3(1)) + vp_2(1)*vp_3(1) + -v*(vp_2(2)+vp_3(2)) + vp_2(2)*vp_3(2) == ...
                        -u*(vp_3(1)+vp_1(1)) + vp_3(1)*vp_1(1) + -v*(vp_3(2)+vp_1(2)) + vp_3(2)*vp_1(2),...
                        -u*(vp_1(1)+vp_2(1)) + vp_1(1)*vp_2(1) + -v*(vp_1(2)+vp_2(2)) + vp_1(2)*vp_2(2) == ...
                        -u*(vp_3(1)+vp_1(1)) + vp_3(1)*vp_1(1) + -v*(vp_3(2)+vp_1(2)) + vp_3(2)*vp_1(2));
    syms f;
    [f_sol] = solve((u_sol - vp_2(1))*(u_sol - vp_3(1)) + (v_sol - vp_2(2))*(v_sol - vp_3(2)) + f*f == 0);

    f = double(f_sol);
    f = f(1);
    u = double(u_sol);
    v = double(v_sol);

    K = [f      0       u;
         0      f       v;
         0      0       1];                
    %rotation matrix                
    r_x = inv(K)*vp_1;
    r_y = inv(K)*vp_2;
    r_z = inv(K)*vp_3;

    r_x = r_x / sqrt(sumsqr(r_x));
    r_y = r_y / sqrt(sumsqr(r_y));
    r_z = r_z / sqrt(sumsqr(r_z));

    R = [r_x r_y r_z]; 

    % measure height
    figure(3);
    imagesc(input);
    hold on;
    [x1,y1] = ginput(1);
    [x2,y2] = ginput(1);
    plot([x1 x2], [y1 y2], 'r', 'LineWidth', 3);
    b0 = [x1 y1 1];
    t0 = [x2 y2 1];

    % put height spec here.
    H = 100;

    %reference_points = load('reference_points.mat');
    %reference_points = reference_points.reference_points;
    [x1, y1] = ginput(1);
    [x2, y2] = ginput(1);
    plot([x1 x2], [y1 y2], 'b', 'LineWidth', 3);
    reference_points = [x1, y1, 1, x2, y2, 1];


    height = zeros(size(reference_points, 1), 1);

    %{
    figure();
    imagesc(input);
    hold on;
    plot(reference_points(1,1), reference_points(1,2),  'r*');
    plot(reference_points(1,4), reference_points(1,5),  'g*');

    figure();
    imagesc(input);
    hold on;
    plot(reference_points(2,1), reference_points(2,2),  'r*');
    plot(reference_points(2,4), reference_points(2,5),  'g*');

    figure();
    imagesc(input);
    hold on;
    plot(reference_points(3,1), reference_points(3,2),  'r*');
    plot(reference_points(3,4), reference_points(3,5),  'g*');
    %}
    for i = 1:size(reference_points, 1)
        b = reference_points(i, 1:3);
        r = reference_points(i, 4:6);
        line1 = real(cross(b0', b'));
        v = real(cross(line1, horizon));
        v = v/v(3);

        line2 = real(cross(v', t0'));
        vertical_line = real(cross(r', b'));
        t = real(cross(line2', vertical_line'));
        t = t/t(3);

        %draw pictures
        figure();
        imagesc(input);
        hold on;
        plot([vp_1(1) vp_2(1)], [vp_1(2) vp_2(2)]);
        plot([v(1) b0(1)], [v(2) b0(2)], 'r');
        plot([t0(1) b0(1)], [t0(2) b0(2)], 'r');
        plot([v(1) t0(1)], [v(2) t0(2)], 'r');
        plot([v(1) t(1)], [v(2) t(2)], 'g');
        plot([b(1) t(1)], [b(2) t(2)], 'g');
        plot([b(1) v(1)], [b(2) v(2)], 'g');
        plot([b(1) r(1)], [b(2) r(2)], 'y');
        axis equal;
        axis image;

        height(i) = H*sqrt(sumsqr(r-b))*sqrt(sumsqr(vp_1-t))/...
            sqrt(sumsqr(t-b))/sqrt(sumsqr(vp_1-r))
    end
end
