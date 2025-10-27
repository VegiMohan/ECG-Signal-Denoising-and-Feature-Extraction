%% ECG Signal Denoising and Feature Extraction (MATLAB)

%% Parameters
fs = 360;             % Sampling frequency (Hz)
t = 0:1/fs:10;        % 10-second duration

%% Generate synthetic ECG-like signal
ecgSignal = 0.5*sin(2*pi*1.7*t) + ...   % P-wave + T-wave
            sin(2*pi*1.2*t) + ...       % QRS complex
            0.05*randn(size(t));        % Add small noise

%% Plot original ECG
figure;
plot(t, ecgSignal);
xlabel('Time (s)');
ylabel('Amplitude');
title('Original Synthetic ECG Signal');
grid on;

%% Design Filters
% 1. Bandpass Filter (0.5 - 40 Hz)
bpFilt = designfilt('bandpassfir','FilterOrder',100, ...
         'CutoffFrequency1',0.5,'CutoffFrequency2',40, ...
         'SampleRate',fs);
ecgFiltered = filter(bpFilt, ecgSignal);

% 2. Notch Filter at 50 Hz to remove powerline interference
d = designfilt('bandstopiir','FilterOrder',2, ...
               'HalfPowerFrequency1',49,'HalfPowerFrequency2',51, ...
               'DesignMethod','butter','SampleRate',fs);
ecgFiltered = filter(d, ecgFiltered);

%% Plot filtered ECG
figure;
plot(t, ecgFiltered);
xlabel('Time (s)');
ylabel('Amplitude');
title('Filtered ECG Signal');
grid on;

%% Frequency Analysis (FFT)
N = length(ecgFiltered);
f = (0:N-1)*(fs/N);  % Frequency axis
ECG_FFT = abs(fft(ecgFiltered));

figure;
plot(f, ECG_FFT);
xlim([0 60]);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('ECG Signal FFT');
grid on;

%% Short-Time Fourier Transform (STFT)
window = 256;
noverlap = 128;
nfft = 512;

figure;
spectrogram(ecgFiltered, window, noverlap, nfft, fs, 'yaxis');
title('ECG Signal STFT');

%% R-Peak Detection (Simple method using findpeaks)
[peaks, locs] = findpeaks(ecgFiltered, 'MinPeakHeight',0.8, 'MinPeakDistance', fs*0.6);

figure;
plot(t, ecgFiltered);
hold on;
plot(t(locs), peaks, 'ro');
xlabel('Time (s)');
ylabel('Amplitude');
title('R-Peak Detection');
grid on;

%% Heart Rate Calculation
RR_intervals = diff(locs)/fs;  % in seconds
heartRate = 60 ./ RR_intervals; % bpm

fprintf('Average Heart Rate: %.2f bpm\n', mean(heartRate));
