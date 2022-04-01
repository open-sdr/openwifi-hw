function test_data_in_out
clear all;
close all;

% a = round(randn(2000,1).*1000);
% fp = fopen('data_in.txt', 'w');
% for i=1:length(a)
%     fprintf(fp, '%d\n', a(i));
% end
% fclose(fp);

data_in = load('data_in.txt');

data_out_golden = mv_avg(data_in, 32);
subplot(2,1,1); plot(data_out_golden, 'b'); hold on; grid on;
data_out = load('data_out.txt');
subplot(2,1,1); plot(data_out, 'r*-');
data_out_new = load('data_out_new.txt');
subplot(2,1,1); plot(data_out_new, 'ks-');

data_out128_golden = mv_avg(data_in, 128);
subplot(2,1,2); plot(data_out128_golden, 'b'); hold on; grid on;
data_out128 = load('data_out128.txt');
subplot(2,1,2); plot(data_out128, 'r*-');
data_out128_new = load('data_out128_new.txt');
subplot(2,1,2); plot(data_out128_new, 'ks-');

figure; 
subplot(2,2,1); plot(data_out_golden(1:997) - data_out);
subplot(2,2,2); plot(data_out_golden(1:999) - data_out_new);
subplot(2,2,3); plot(data_out128_golden(1:997) - data_out128);
subplot(2,2,4); plot(data_out128_golden(1:999) - data_out128_new);

function a = mv_avg(b, mv_avg_len)
c = [zeros(mv_avg_len-1,1); b];
a = zeros(length(b),1);
for i=1:length(b)
    a(i) = floor(sum(c(i:(i+mv_avg_len-1)))./mv_avg_len);
end
