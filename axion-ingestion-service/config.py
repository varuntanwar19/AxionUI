"""
Axion Ingestion Service - Configuration
Loads database connection string from environment variable.
"""

import os
import sys
from dataclasses import dataclass


@dataclass
class Settings:
    # PostgreSQL connection string
    # Format: postgresql://<user>:<password>@<host>:<port>/<database>
    # Example: postgresql://postgres:postgres@localhost:5432/axiondb
    DATABASE_URL: str = os.getenv("DATABASE_URL")
    def __post_init__(self):
        # Loud failure if DATABASE_URL is missing
        if not self.DATABASE_URL:
            print("CRITICAL ERROR: 'DATABASE_URL' environment variable is missing!")
            sys.exit(1)

settings = Settings()
