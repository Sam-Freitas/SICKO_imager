import cv2
import time

def open_camera_and_capture_images():
    # Specify the camera index (0 for the default camera)
    camera_index = 0

    # Open the camera
    cap = cv2.VideoCapture(camera_index)

    if not cap.isOpened():
        print("Error: Could not open camera.")
        return

    # Set the desired resolution for capturing
    desired_width = 5472
    desired_height = 3648

    cap.set(cv2.CAP_PROP_FRAME_WIDTH, desired_width)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, desired_height)

    # Set the desired resolution for display
    display_width = 684
    display_height = 684

    # Set the desired crop size
    crop_size = 2000

    # Variables for FPS calculation
    start_time = time.time()
    frame_count = 0

    while True:
        # Capture frame-by-frame
        ret, frame = cap.read()

        # Check if the frame is None
        if frame is None:
            print("Error: Couldn't capture a frame.")
            break

        # Crop the center 1500x1500 pixels
        h, w = frame.shape[:2]
        start_row = int((h - crop_size) / 2)
        start_col = int((w - crop_size) / 2)
        cropped_frame = frame[start_row:start_row + crop_size, start_col:start_col + crop_size]

        # Resize the cropped frame for display
        resized_frame = cv2.resize(cropped_frame, (display_width, display_height))

        # Flip the frame based on arrow keys
        key = cv2.waitKey(1) & 0xFF
        if key == 27:  # Break the loop if 'Esc' key is pressed
            break

        # Display the resized frame
        cv2.imshow('Camera', resized_frame)

        # Save the cropped frame to a file (optional)
        # cv2.imwrite('cropped_image.jpg', cropped_frame)

        # Calculate and print FPS
        frame_count += 1
        elapsed_time = time.time() - start_time

        if elapsed_time >= 1.0:
            fps = frame_count / elapsed_time
            print(f"FPS: {fps:.2f}")
            start_time = time.time()
            frame_count = 0

    # Release the camera and close all OpenCV windows
    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    open_camera_and_capture_images()
