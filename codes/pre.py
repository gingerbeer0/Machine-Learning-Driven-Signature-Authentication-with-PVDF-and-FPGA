import os
import glob
import pandas as pd
import matplotlib.pyplot as plt

# 1. CSV 파일이 있는 폴더 경로 설정
folder_path = r"C:/Users/JEJE/Desktop/csv/data_realfake/result_fake"

# 2. 폴더 내 모든 CSV 파일 경로 조회
csv_files = glob.glob(os.path.join(folder_path, "*.csv"))

# 3. 각 CSV 파일에 대해 반복 처리
for csv_file in csv_files:
    # (선택) 파일명 확인용 출력
    print(f"처리 중인 파일: {csv_file}")

    # 3-1) CSV 파일 로드
    #     만약 첫 번째 행이 필요 없는 헤더라면 skiprows=1 사용
    #     (불필요하다면 skiprows 옵션을 제거하거나 수정하세요)
    df = pd.read_csv(csv_file, skiprows=1)

    # 3-2) 컬럼명 수정 (실제로 CSV 파일의 헤더 구조와 맞춰야 함)
    df.columns = ["time (s)", "voltage (V)"]

    # 3-3) 데이터 타입 변환 (문자열 → 숫자)
    df["time (s)"] = pd.to_numeric(df["time (s)"], errors="coerce")
    df["voltage (V)"] = pd.to_numeric(df["voltage (V)"], errors="coerce")

    # 3-4) 그래프 그리기
    plt.figure(figsize=(8, 4))
    plt.plot(df["time (s)"], df["voltage (V)"], marker="o", linestyle="-", color="b")
    plt.xlabel("Time (s)")
    plt.ylabel("Voltage (V)")
    plt.title("PVDF Sensor Signal")
    plt.grid(True)

    # 3-5) 그래프를 PNG 파일로 저장
    #     CSV 파일 이름만 추출하여 확장자를 PNG로 변경
    base_name = os.path.splitext(os.path.basename(csv_file))[0]
    save_path = os.path.join(folder_path, f"{base_name}.png")
    plt.savefig(save_path, dpi=300)  # 해상도 300으로 저장

    # (선택) 그래프 창 닫기
    plt.close()

    print(f"이미지 저장 완료: {save_path}")
