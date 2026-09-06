"""
Axion Telemetry Query Service - Configuration
"""

import os
import sys
from dataclasses import dataclass

@dataclass
class Settings:
    # PostgreSQL connection string
    # Format: postgresql://<user>:<password>@<host>:<port>/<database>
    DATABASE_URL: str = os.getenv("DATABASE_URL")
    def __post_init__(self):
            # Loud failure if DATABASE_URL is missing
            if not self.DATABASE_URL:
                print("CRITICAL ERROR: 'DATABASE_URL' environment variable is missing!")
                sys.exit(1)
    # Allows configuring a different port, e.g., if we run multiple services
    PORT: int = int(os.getenv("PORT"))

settings = Settings()
