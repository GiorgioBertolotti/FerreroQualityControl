function out=equalize_image(image)
    %{
    red_ch = image(:,:,1);
    green_ch = image(:,:,2);
    blue_ch = image(:,:,3);
    out = [histeq(red_ch), histeq(green_ch), histeq(blue_ch)];
    %out = [histeq(red_ch, 255), histeq(green_ch, 255), histeq(blue_ch, 255)];
    %}
    out = image;
    out(:,:,1) = histeq(out(:,:,1));
    out(:,:,2) = histeq(out(:,:,2));
    out(:,:,3) = histeq(out(:,:,3));
end
