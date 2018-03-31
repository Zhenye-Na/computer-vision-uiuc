function features_show(img_left_rgb, img_right_rgb, matches, final_matches)
    figure; imshow(img_left_rgb); hold on;
    scatter(matches(:, 2), matches(:, 1), 'g');
    scatter(final_matches(:, 2), final_matches(:, 1), 'r', '+');
    
    figure; imshow(img_right_rgb); hold on;
    scatter(matches(:, 4), matches(:, 3), 'g');
    scatter(final_matches(:, 4), final_matches(:, 3), 'r', '+');

end

