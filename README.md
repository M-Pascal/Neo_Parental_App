# **NeoParental**
## Project overview
NeoParental is an AI-powered mobile application designed to support new parents in Rwanda, particularly in Kigali, as they navigate early parenthood. The system analyzes and interprets infant cries to help caregivers understand their baby’s needs in real time, reducing stress and improving response to health concerns. It integrates with Community Health Workers to strengthen follow-up and early interventions, contributing to better maternal and child health outcomes.

This project was developed as a BSc. in Software Engineering thesis by Pascal Mugisha, supervised by Mr. Emmanuel, and intended to be completed in November 2025.

#### Important Links to Explore:
- Link to [Figma Design Prototype](https://www.figma.com/proto/VEoDYp7vbH6ahN5du9bKWb/Untitled?node-id=0-1&t=tz9GGUXJTJ9oRpkr-1)
- Link to [GitHub Repository](https://github.com/M-Pascal/NeoParental.git)
- Link to [Demo_video](https://youtu.be/mBu3su7Ymdk)
[![YouTube Video mBu3su7Ymdk](https://img.youtube.com/vi/mBu3su7Ymdk/maxresdefault.jpg)](https://www.youtube.com/watch?v=mBu3su7Ymdk)
## Project Structure
```
NeoParental/
│
├── Model/
│   └── Capstone_project_NeoParental.ipynb  # model
│
├── Sound_data/
│   └── (audio dataset labels)  # Labels sounds
│
└── README.md
```

## Technology Stack
### Frontend
- Framework: Flutter
- State Management: Provider
### Backend
- Framework: Python (FastAPI)
### AI/ML Components
- Data Processing: librosa

## Prerequisites
To run the NeoParental system, you'll need:

* **Python 3.9+** - For backend development
* **Flutter SDK** - For mobile application development
* **Node.js v18.x** - For certain development tools

## Installation & Setup
1. Clone the repository:
```bash
git clone https://github.com/M-Pascal/NeoParental.git
cd NeoParental/
```
2. Create Virtual Environment:
```bash
python -m venv myvenv
source myenv/Scripts/activate  # On macOS: myenv\bin\activate
```
3. Install dependencies:
```bash
pip install -r requirements.txt
```
## Contributing
To contribute to the NeoParental project:

1. Fork the repository
2. Create a feature branch (git checkout -b new_ideas)
3. Commit your changes (git commit -m 'Added features')
4. Push to the branch (git push origin new_ideas)
5. Open a Pull Request

## Acknowledgements
- Emmanuel Annor - Project Supervisor
