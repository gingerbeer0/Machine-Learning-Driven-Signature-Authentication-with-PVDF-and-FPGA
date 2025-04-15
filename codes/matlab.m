clc; clear;
%% 1. 폴더 내 모든 CSV 파일 읽기
folder_path = 'C:\Users\2009e\OneDrive\문서\MATLAB\plus\fake'; % CSV 파일이 있는 폴더
csv_files = dir(fullfile(folder_path, '*.csv')); % 폴더 내 모든 CSV 파일 리스트
num_files = length(csv_files); % 파일 개수 확인
% 모든 CSV 파일 반복 처리
for i = 1:num_files
    %% 2. 파일 로드 및 데이터 변환
    csv_filename1 = csv_files(i).name;
    csv_filename = csv_filename1(1:end-4); % 확장자 제거 (파일 이름)
    full_csv_path = fullfile(folder_path, csv_filename1);
    % CSV 파일 읽기 (첫 2줄 무시)
    data = readtable(full_csv_path, 'HeaderLines', 2);
    % 데이터 변환 (셀 데이터를 숫자로 변환)
    if iscell(data.Var1)
        data.Var1 = str2double(data.Var1);
    end
    if iscell(data.Var2)
        data.Var2 = str2double(data.Var2);
    end
    % 배열 변환
    data_array = table2array(data);
    % 시간 값과 신호 값 추출
    time = data_array(:, 1);
    signal = data_array(:, 2);
    time = time - time(1); % 시간 0으로 정규화
    %% 3. 샘플링 주파수 계산
    dt = mean(diff(time));
    fs = 1 / dt;
    %% 4. NaN 및 Inf 값 처리
    signal = fillmissing(signal, 'linear'); % NaN을 선형 보간
    signal(isinf(signal)) = 0; % Inf 값 제거
    signal = double(signal);
    %% 5. 신호 양자화 (12비트 ADC)
    adc_bits = 12;
    adc_max = 2^(adc_bits-1) - 1;
    signal_quantized = round(signal * adc_max) / adc_max;
    %% 6. IIR 필터 설계 및 적용
    % 대역 통과 필터 (20~80Hz)
    a1 = -1.97725005; a2 = 0.97750586;
    b0 = 6.39525837e-5; b1 = 1.27905167e-4; b2 = 6.39525837e-5;
    b_iir = [b0 b1 b2];
    a_iir = [1 a1 a2];
    signal_bandpass = filter(b_iir, a_iir, signal_quantized);
    % 60Hz 노치 필터
    a1_60 = -1.98293720; a2_60 = 0.98308151;
    b0_60 = 0.99154075; b1_60 = -1.98293720; b2_60 = 0.99154075;
    b_60 = [b0_60 b1_60 b2_60];
    a_60 = [1 a1_60 a2_60];
    signal_notched_60 = filter(b_60, a_60, signal_bandpass);
    % 120Hz 노치 필터
    a1_120 = -1.96587691; a2_120 = 0.96644925;
    b0_120 = 0.98322462; b1_120 = -1.96587691; b2_120 = 0.98322462;
    b_120 = [b0_120 b1_120 b2_120];
    a_120 = [1 a1_120 a2_120];
    signal_notched_60_120 = filter(b_120, a_120, signal_notched_60);
        %% 7. signal_feature_range 생성
    sfr = [time, signal_notched_60_120];
    % 신호의 피크(최댓값) 찾기
    [pks_max, locs_max] = findpeaks(signal_notched_60_120, time);
    [pks_min, locs_min] = findpeaks(-signal_notched_60_120, time); % 최솟값 찾기 (부호 반전)
    % 첫 번째와 마지막 피크 시간 찾기
    if ~isempty(locs_max) && ~isempty(locs_min)
        first_peak_time = min(locs_max(1), locs_min(1)); % 첫 번째 피크 시간
        last_peak_time = max(locs_max(end), locs_min(end)); % 마지막 피크 시간
    else
        % 피크가 없으면 기존 방식으로 최솟값과 최댓값의 시간 사용
        min_val = min(signal_notched_60_120);
        max_val = max(signal_notched_60_120);
        first_peak_time = min(time(signal_notched_60_120 == min_val));
        last_peak_time = max(time(signal_notched_60_120 == max_val));
    end
    % 첫 번째 피크 ~ 마지막 피크 사이의 데이터 선택
    valid_indices = (time >= first_peak_time) & (time <= last_peak_time);
    signal_feature_range = sfr(valid_indices, :);  % 유효한 데이터만 저장
    %% 8. 데이터 저장 (CSV)
    folder_path2 = 'C:\Users\2009e\OneDrive\문서\MATLAB\plus\fake\result_fake';
    output_filename = fullfile(folder_path2, strcat(csv_filename, '_filtered.csv'));
    writematrix(signal_feature_range, output_filename);
    % 파일 저장 완료 메시지 출력
    fprintf(':white_check_mark: %s 처리 완료 → 저장됨: %s\n', csv_filename1, output_filename);
    %% 9. 시각화 (처리된 신호 & FFT)
    figure;
    % 필터링된 신호 시각화
    subplot(2,1,1);
    plot(signal_feature_range(:, 1), signal_feature_range(:, 2), 'r', 'LineWidth', 1.5);
    grid on;
    xlabel('Time (s)');
    ylabel('Amplitude');
    title(['Filtered Signal (' csv_filename ')']);
    % FFT 계산 및 시각화
    N = length(signal);
    f = (0:N-1)*(fs/N);
    Xf_filtered = abs(fft(signal_notched_60_120)/N);
    Xf_filtered_one_side = 2 * Xf_filtered(1:floor(N/2));
    f_filtered_one_side = f(1:floor(N/2));
    subplot(2,1,2);
    plot(f_filtered_one_side(f_filtered_one_side <= 300), Xf_filtered_one_side(f_filtered_one_side <= 300), 'b');
    grid on;
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    title(['FFT of Filtered Signal (' csv_filename ')']);
end
disp(':white_check_mark: 모든 파일 처리 완료!');