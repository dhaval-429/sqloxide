#!/bin/bash
set -ex

curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable -y
export PATH="$HOME/.cargo/bin:$PATH"

cd $GITHUB_WORKSPACE/io
cd io

for PYBIN in /opt/python/cp{37,38,39,310,311}*/bin; do
    "${PYBIN}/pip" install -U setuptools wheel setuptools-rust
    "${PYBIN}/python" setup.py bdist_wheel
done

for whl in dist/*.whl; do
    auditwheel repair "$whl" -w dist/
done

cd ..
for PYBIN in /opt/python/cp{37,38,39,310,311}*/bin; do
    "${pybin}/pip" install ${PACKAGE_NAME} --no-index -f dist/
    "${pybin}/pytest" tests/test_sqloxide.py
done