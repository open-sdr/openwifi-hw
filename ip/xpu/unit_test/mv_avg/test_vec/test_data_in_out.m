function test_data_in_out
clear all;
close all;

% a = round(randn(2000,1).*1000);
% fp = fopen('data_in.txt', 'w');
% for i=1:length(a)
%     fprintf(fp, '%d\n', a(i));
% end
% fclose(fp);

% data_in = load('data_in_sync_short_prod.txt');
data_in = load('data_in.txt');

data_out_golden = mv_avg(data_in, 32);
data_out_golden(1:2) = [];
data_out_golden(500:501) = [];
data_out_golden(1000:1002) = [];
data_out_golden(1500:1501) = [];
% subplot(2,1,1); 
plot(data_out_golden, 'b'); hold on; grid on;
% data_out = load('data_out.txt');
% subplot(2,1,1); plot(data_out, 'r*-');
data_out_new = load('data_out_new.txt');
% subplot(2,1,1); 
plot(data_out_new, 'r');
legend('golden', 'verilog');

% data_out128_golden = mv_avg(data_in, 128);
% subplot(2,1,2); plot(data_out128_golden, 'b'); hold on; grid on;
% % data_out128 = load('data_out128.txt');
% % subplot(2,1,2); plot(data_out128, 'r*-');
% data_out128_new = load('data_out128_new.txt');
% subplot(2,1,2); plot(data_out128_new, 'r.');

figure; 
% subplot(2,2,1); plot(data_out_golden(1:997) - data_out);
% subplot(2,1,1); 
plot(data_out_golden(1:length(data_out_new)) - data_out_new);
% subplot(2,2,3); plot(data_out128_golden(1:997) - data_out128);
% subplot(2,1,2); plot(data_out128_golden(1:length(data_out128_new)) - data_out128_new);

% dual channel version
figure;
data_out_golden0 = mv_avg(data_in, 16);
data_out_golden0(1:2) = [];
data_out_golden0(500:501) = [];
data_out_golden0(1000:1002) = [];
data_out_golden0(1500:1501) = [];
data_out_golden1 = mv_avg(-data_in, 16);
data_out_golden1(1:2) = [];
data_out_golden1(500:501) = [];
data_out_golden1(1000:1002) = [];
data_out_golden1(1500:1501) = [];
plot(data_out_golden0, 'b'); hold on; grid on;
plot(data_out_golden1, 'b--'); hold on; grid on;
a = load('data_out_dual_ch.txt');
data_out0 = a(:,1);
data_out1 = a(:,2);
plot(data_out0, 'r');
plot(data_out1, 'r--');
legend('golden0', 'golden1', 'verilog0', 'verilog1');

figure; 
plot(data_out_golden0(1:length(data_out0)) - data_out0, 'b'); hold on; grid on;
plot(data_out_golden1(1:length(data_out0)) - data_out1, 'r'); 

function a = mv_avg(b, mv_avg_len)
c = [zeros(mv_avg_len-1,1); b];
a = zeros(length(b),1);
for i=1:length(b)
    a(i) = floor(sum(c(i:(i+mv_avg_len-1)))./mv_avg_len);
end
