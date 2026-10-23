FROM python:3.12-slim
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
COPY solver-bundle.zip /tmp/solver-bundle.zip
COPY unpack_solver.py /tmp/unpack_solver.py
RUN python3 /tmp/unpack_solver.py /tmp/solver-bundle.zip /app \
    && rm -f /tmp/solver-bundle.zip /tmp/unpack_solver.py \
    && chmod -R a+rX /app
CMD ["bash"]
