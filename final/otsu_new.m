function level = otsu(histogramCounts, total)

wB = 0.0;%weight of background pixels
sumB = 0.0;%the sum of all background gray values * their number of pixels
maximum = 0.0;%maximum variance
threshold1 = 0.0;
threshold2 = 0.0;
sum1 = sum((1:256).*histogramCounts.'); 
for ii = 256:-1:1 %traverse the gray histogram from back to front, find the first grayscale whose number is not zero
    if (histogramCounts(ii) ~= 0)
        min_gray = ii;%the first grayscale whose number is not zero in the histogram from back to front
        break;
    end
end

%Use the gray value as the threshold to calculate the maximum between-class variance
for ii=1:fix(min_gray/2)
    wB = wB + histogramCounts(ii);
    if (histogramCounts(ii) == 0)
       continue; 
    end
    wF = total - wB;%weight of foreground pixels in the image
    if (wF == 0)
        break;
    end
    sumB = sumB +  ii * histogramCounts(ii);
    mB = sumB / wB;
    mF = (sum1 - sumB) / wF;
    between = wB * wF * (mB - mF) * (mB - mF);%between-class variance
    if ( between >= maximum )
        threshold1 = ii;
        if ( between > maximum )
            threshold2 = ii;
        end
        maximum = between;
    end
end
level = (threshold1 + threshold2 )/(2);%the best threshold of the image
end