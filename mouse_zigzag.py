import pyautogui
import time

def zigzag_motion(duration=60, step=50, interval=0.1):
    """
    Moves the mouse in a zigzag pattern for a specified duration.

    Parameters:
        duration (int): Duration in seconds for which the zigzag motion will be performed.
        step (int): Distance in pixels for each step in the zigzag motion.
        interval (float): Time interval in seconds between each movement.
    """
    start_time = time.time()
    width, height = pyautogui.size()
    x, y = width // 2, height // 2

    pyautogui.moveTo(x, y)  # Move the mouse to the center of the screen

    direction = 1
    while time.time() - start_time < duration:
        # Move the mouse horizontally
        pyautogui.moveRel(step * direction, 0, duration=interval)
        # Move the mouse vertically
        pyautogui.moveRel(0, step * direction, duration=interval)
        direction *= -1
        time.sleep(interval)

if __name__ == "__main__":
    zigzag_motion(duration=60, step=50, interval=0.1)

