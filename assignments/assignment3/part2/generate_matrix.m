function [A] = generate_matrix(matches, inliers)
    A = [];
    num_of_inliers = size(inliers,1);

    for i = 1:num_of_inliers
        u = matches(inliers(i), 1);
        v = matches(inliers(i), 2);
        u_prime = matches(inliers(i), 3);
        v_prime = matches(inliers(i), 4); 

        A = [A; u_prime*u, u_prime*v, u_prime, v_prime*u, v_prime*v, v_prime, u, v, 1];
    end

end